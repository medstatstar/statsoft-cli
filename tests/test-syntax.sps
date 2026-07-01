* test-syntax.sps — SPSS 测试语法文件
* 用于验证 SPSS 无闪屏调用方式是否正常
* 使用方法：将工作目录设为 tests/ 后运行

* 生成测试数据
INPUT PROGRAM.
  LOOP id = 1 TO 5.
    COMPUTE score = id * 10.
    END CASE.
  END LOOP.
  END FILE.
END INPUT PROGRAM.

* 保存数据（相对路径，工作目录为 tests/）
SAVE OUTFILE="test-data.sav".

* 描述统计
DESCRIPTIVES VARIABLES=score
  /STATISTICS=MEAN STDDEV MIN MAX.
