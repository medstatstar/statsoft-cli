* test-syntax.sps — SPSS 测试语法文件
* 用于验证 SPSS 无闪屏调用方式是否正常

* 生成测试数据
INPUT PROGRAM.
  LOOP id = 1 TO 5.
    COMPUTE score = id * 10.
    END CASE.
  END LOOP.
  END FILE.
END INPUT PROGRAM.

* 保存数据
SAVE OUTFILE="C:/Users/WintoneFileSrv/WorkBuddy/2026-06-29-13-58-39/spss-test/test-data.sav".

* 描述统计
DESCRIPTIVES VARIABLES=score
  /STATISTICS=MEAN STDDEV MIN MAX.
